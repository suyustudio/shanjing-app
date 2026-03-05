.class public final Lf1/i;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Lf1/b;


# annotations
.annotation system Ldalvik/annotation/Signature;
    value = {
        "<T:",
        "Ljava/lang/Object;",
        "R:",
        "Ljava/lang/Object;",
        ">",
        "Ljava/lang/Object;",
        "Lf1/b<",
        "TR;>;"
    }
.end annotation


# instance fields
.field private final a:Lf1/b;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Lf1/b<",
            "TT;>;"
        }
    .end annotation
.end field

.field private final b:La1/l;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "La1/l<",
            "TT;TR;>;"
        }
    .end annotation
.end field


# direct methods
.method public constructor <init>(Lf1/b;La1/l;)V
    .locals 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Lf1/b<",
            "+TT;>;",
            "La1/l<",
            "-TT;+TR;>;)V"
        }
    .end annotation

    const-string v0, "sequence"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/i;->e(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "transformer"

    invoke-static {p2, v0}, Lkotlin/jvm/internal/i;->e(Ljava/lang/Object;Ljava/lang/String;)V

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lf1/i;->a:Lf1/b;

    iput-object p2, p0, Lf1/i;->b:La1/l;

    return-void
.end method

.method public static final synthetic a(Lf1/i;)Lf1/b;
    .locals 0

    iget-object p0, p0, Lf1/i;->a:Lf1/b;

    return-object p0
.end method

.method public static final synthetic b(Lf1/i;)La1/l;
    .locals 0

    iget-object p0, p0, Lf1/i;->b:La1/l;

    return-object p0
.end method


# virtual methods
.method public iterator()Ljava/util/Iterator;
    .locals 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Ljava/util/Iterator<",
            "TR;>;"
        }
    .end annotation

    new-instance v0, Lf1/i$a;

    invoke-direct {v0, p0}, Lf1/i$a;-><init>(Lf1/i;)V

    return-object v0
.end method
