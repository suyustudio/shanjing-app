.class Lt/d$a;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Lt/f;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lt/d;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = "a"
.end annotation


# instance fields
.field final a:Lj0/k$d;

.field final synthetic b:Lt/d;


# direct methods
.method constructor <init>(Lt/d;Lj0/k$d;)V
    .locals 0

    iput-object p1, p0, Lt/d$a;->b:Lt/d;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p2, p0, Lt/d$a;->a:Lj0/k$d;

    return-void
.end method


# virtual methods
.method public a(Ljava/lang/Object;)V
    .locals 1

    iget-object v0, p0, Lt/d$a;->a:Lj0/k$d;

    invoke-interface {v0, p1}, Lj0/k$d;->a(Ljava/lang/Object;)V

    return-void
.end method

.method public b(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Object;)V
    .locals 1

    iget-object v0, p0, Lt/d$a;->a:Lj0/k$d;

    invoke-interface {v0, p1, p2, p3}, Lj0/k$d;->b(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Object;)V

    return-void
.end method
