.class Lx/c$f;
.super Ljava/lang/Object;
.source "SourceFile"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lx/c;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0xa
    name = "f"
.end annotation


# instance fields
.field public final a:Lj0/c$a;

.field public final b:Lx/c$d;


# direct methods
.method constructor <init>(Lj0/c$a;Lx/c$d;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lx/c$f;->a:Lj0/c$a;

    iput-object p2, p0, Lx/c$f;->b:Lx/c$d;

    return-void
.end method
