.class final Lh1/r1$a;
.super Lh1/q1;
.source "SourceFile"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lh1/r1;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x1a
    name = "a"
.end annotation


# instance fields
.field private final h:Lh1/r1;

.field private final i:Lh1/r1$b;

.field private final j:Lh1/s;

.field private final k:Ljava/lang/Object;


# direct methods
.method public constructor <init>(Lh1/r1;Lh1/r1$b;Lh1/s;Ljava/lang/Object;)V
    .locals 0

    invoke-direct {p0}, Lh1/q1;-><init>()V

    iput-object p1, p0, Lh1/r1$a;->h:Lh1/r1;

    iput-object p2, p0, Lh1/r1$a;->i:Lh1/r1$b;

    iput-object p3, p0, Lh1/r1$a;->j:Lh1/s;

    iput-object p4, p0, Lh1/r1$a;->k:Ljava/lang/Object;

    return-void
.end method


# virtual methods
.method public bridge synthetic invoke(Ljava/lang/Object;)Ljava/lang/Object;
    .locals 0

    check-cast p1, Ljava/lang/Throwable;

    invoke-virtual {p0, p1}, Lh1/r1$a;->y(Ljava/lang/Throwable;)V

    sget-object p1, Lq0/q;->a:Lq0/q;

    return-object p1
.end method

.method public y(Ljava/lang/Throwable;)V
    .locals 3

    iget-object p1, p0, Lh1/r1$a;->h:Lh1/r1;

    iget-object v0, p0, Lh1/r1$a;->i:Lh1/r1$b;

    iget-object v1, p0, Lh1/r1$a;->j:Lh1/s;

    iget-object v2, p0, Lh1/r1$a;->k:Ljava/lang/Object;

    invoke-static {p1, v0, v1, v2}, Lh1/r1;->t(Lh1/r1;Lh1/r1$b;Lh1/s;Ljava/lang/Object;)V

    return-void
.end method
